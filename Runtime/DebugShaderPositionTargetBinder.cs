using UnityEngine;

namespace DebugShaderPack.NumericDisplay
{
    [AddComponentMenu("Debug Shader Pack/Numeric Display/Position Target Binder")]
    [DisallowMultipleComponent]
    [ExecuteAlways]
    public sealed class DebugShaderPositionTargetBinder : MonoBehaviour
    {
        private static readonly int DebugPositionWSId = Shader.PropertyToID("_debug_positionWS");

        [SerializeField]
        private Transform positionTarget;

        private MaterialPropertyBlock propertyBlock;
        private Renderer[] cachedRenderers;

        public Transform PositionTarget
        {
            get => positionTarget;
            set
            {
                positionTarget = value;
                ApplyPositionToRenderers();
            }
        }

        private void Reset()
        {
            CacheRenderers();
            ApplyPositionToRenderers();
        }

        private void OnEnable()
        {
            CacheRenderers();
            ApplyPositionToRenderers();
        }

        private void OnValidate()
        {
            CacheRenderers();
            ApplyPositionToRenderers();
        }

        private void LateUpdate()
        {
            ApplyPositionToRenderers();
        }

        private void OnTransformChildrenChanged()
        {
            CacheRenderers();
            ApplyPositionToRenderers();
        }

        private void CacheRenderers()
        {
            cachedRenderers = GetComponentsInChildren<Renderer>(true);
        }

        private void ApplyPositionToRenderers()
        {
            if (!isActiveAndEnabled)
            {
                return;
            }

            if (cachedRenderers == null || cachedRenderers.Length == 0)
            {
                CacheRenderers();
            }

            if (propertyBlock == null)
            {
                propertyBlock = new MaterialPropertyBlock();
            }

            Transform target = positionTarget != null ? positionTarget : transform;
            Vector3 worldPosition = target.position;
            Vector4 shaderValue = new Vector4(worldPosition.x, worldPosition.y, worldPosition.z, 0f);

            for (int i = 0; i < cachedRenderers.Length; i++)
            {
                Renderer currentRenderer = cachedRenderers[i];
                if (currentRenderer == null)
                {
                    continue;
                }

                currentRenderer.GetPropertyBlock(propertyBlock);
                propertyBlock.SetVector(DebugPositionWSId, shaderValue);
                currentRenderer.SetPropertyBlock(propertyBlock);
            }
        }
    }
}
